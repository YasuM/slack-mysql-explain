const { App, LogLevel } = require("@slack/bolt");
const mysql = require("mysql2");

const app = new App({
  token: process.env.SLACK_BOT_TOKEN,
  logLevel: LogLevel.DEBUG,
  signingSecret: process.env.SLACK_SIGNING_SECRET,
  socketMode: true,
  appToken: process.env.SLACK_APP_TOKEN,
});

async function mysql_connection(schema) {
  const connection = await mysql.createConnection({
    host: process.env.MYSQL_HOST,
    user: process.env.MYSQL_USER,
    password: process.env.MYSQL_PASSWORD,
    database: schema,
  });
  return connection;
}

function schema_select_options(schemas) {
  return schemas.map((v) => {
    return {
      text: {
        type: "plain_text",
        text: v,
      },
      value: v,
    };
  });
}

function explain_form_open(slack_client, schemas, trigger_id) {
  slack_client.views.open({
    trigger_id: trigger_id,
    view: {
      type: "modal",
      callback_id: "explain",
      title: {
        type: "plain_text",
        text: "Modal title",
      },
      blocks: [
        {
          type: "input",
          block_id: "schema",
          element: {
            type: "static_select",
            placeholder: {
              type: "plain_text",
              text: "Select an item",
            },
            options: schema_select_options(schemas),
            action_id: "static_select-action",
          },
          label: {
            type: "plain_text",
            text: "SCHEMA",
          },
        },
        {
          type: "input",
          block_id: "sql",
          label: {
            type: "plain_text",
            text: "SQL",
          },
          element: {
            type: "plain_text_input",
            action_id: "sql_input",
            multiline: true,
          },
        },
      ],
      submit: {
        type: "plain_text",
        text: "Submit",
      },
    },
  });
}

app.shortcut("explain", async ({ ack, client, body }) => {
  ack();
  const connection = await mysql_connection("mysql");
  await connection.execute(
    "select schema_name from INFORMATION_SCHEMA.SCHEMATA;",
    (err, results) => {
      const schemas = results.map((v) => {
        return v.SCHEMA_NAME;
      });
      explain_form_open(client, schemas, body.trigger_id);
    },
  );
});

app.view("explain", async ({ ack, view, client }) => {
  ack();
  const sql = view["state"]["values"]["sql"]["sql_input"]["value"];
  const schema = view["state"]["values"]["schema"]["static_select-action"]["selected_option"]["value"];
  const connection = await mysql_connection(schema);

  connection.execute(`explain ${sql}`, (err, result) => {
    if (err != null) {
      result = err.sqlMessage;
    }
    client.chat.postMessage({
      token: process.env.SLACK_BOT_TOKEN,
      channel: process.env.EXPLAIN_RESULT_SLACK_CHANNEL_ID,
      text: JSON.stringify(result, null, 2),
    });
  });
});

(async () => {
  app.start(process.env.PORT || 3000);

  console.log("⚡️ Bolt app is running!");
})();
