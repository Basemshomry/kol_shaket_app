const admin = require("firebase-admin");
const {onValueCreated} = require("firebase-functions/v2/database");

admin.initializeApp();

async function getStaffTokens() {
  const snapshot = await admin.database().ref("users").once("value");

  if (!snapshot.exists()) {
    return [];
  }

  const users = snapshot.val();
  const tokens = [];

  Object.values(users).forEach((user) => {
    if (!user || user.role === "student") return;

    const userTokens = user.fcmTokens || {};

    Object.keys(userTokens).forEach((token) => {
      tokens.push(token);
    });
  });

  return tokens;
}

async function getUserTokens(uid) {
  if (!uid) return [];

  const snapshot = await admin
      .database()
      .ref(`users/${uid}/fcmTokens`)
      .once("value");

  if (!snapshot.exists()) {
    return [];
  }

  return Object.keys(snapshot.val());
}

async function sendNotification(tokens, title, body, data = {}) {
  if (!tokens || tokens.length === 0) return;

  await admin.messaging().sendEachForMulticast({
    tokens,
    notification: {
      title,
      body,
    },
    data,
    android: {
      priority: "high",
      notification: {
        channelId: "kol_shaket_channel",
        sound: "default",
      },
    },
  });
}

exports.onNewReport = onValueCreated(
    "/reports/{reportId}",
    async (event) => {
      const report = event.data.val() || {};
      const tokens = await getStaffTokens();

      const studentName =
      `${report.studentFirstName || ""} ${report.studentLastName || ""}`.trim();

      const category = report.category || "New report";

      await sendNotification(
          tokens,
          "New Report",
          studentName ? `${studentName}: ${category}` : category,
          {
            screen: "reports",
            reportId: event.params.reportId,
            type: "new_report",
          },
      );
    },
);

exports.onNewMessage = onValueCreated(
    "/chats/{reportId}/{chatType}/messages/{messageId}",
    async (event) => {
      const message = event.data.val() || {};

      const reportSnapshot = await admin
          .database()
          .ref(`reports/${event.params.reportId}`)
          .once("value");

      if (!reportSnapshot.exists()) return;

      const report = reportSnapshot.val() || {};

      let tokens = [];

      if (message.senderRole === "student") {
        tokens = await getStaffTokens();
      } else {
        tokens = await getUserTokens(report.studentId);
      }

      await sendNotification(
          tokens,
          "New Message",
          message.message || "You received a new message",
          {
            screen: "chats",
            reportId: event.params.reportId,
            chatType: event.params.chatType,
            type: "new_message",
          },
      );
    },
);