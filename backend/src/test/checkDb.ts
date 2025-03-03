import sequelize from "../config/database";
import GroupMessage from "../models/groupMessage";

const testQuery = async () => {
  try {
    await sequelize.authenticate();
    console.log("✅ Database connection successful.");

    const messages = await GroupMessage.findAll();
    console.log(`✅ Group Messages Count: ${messages.length}`);

    process.exit(0); // Exit script after execution
  } catch (error) {
    console.error("❌ Error:", error);
    process.exit(1);
  }
};

testQuery();
