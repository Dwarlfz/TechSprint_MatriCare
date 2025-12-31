const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
const sgMail = require("@sendgrid/mail");

sgMail.setApiKey("YOUR_SENDGRID_API_KEY");

exports.sendFamilyInvite = functions.firestore
  .document("users/{uid}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // If family list did not change, stop
    if (JSON.stringify(before.family) === JSON.stringify(after.family)) return;

    const newEmails = after.family.filter(email => !before.family?.includes(email));
    if (newEmails.length === 0) return;

    // Send invite email to each newly added address
    for (const email of newEmails) {
      const token = await admin.auth().createCustomToken(email);

      const msg = {
        to: email,
        from: "no-reply@matricare.com",
        subject: "MatriCare Family Access Invitation",
        html: `
          <h2>You’ve been granted access to maternal health records</h2>
          <p>Click the button below to view updates:</p>
          <a href="https://your-app-url.com/family-login?token=${token}">
            <button style="padding:10px;background-color:#ff4081;color:white;border:none;border-radius:6px">
              Access MatriCare
            </button>
          </a>
        `,
      };

      await sgMail.send(msg);
    }

    return true;
  });
