import { DataTypes, Model, Optional } from "sequelize";
import sequelize from "../config/database";
import User from "./user";

interface MessageAttributes {
  id: string;
  senderId: string;
  receiverId: string;
  messageType: string;
  content: string;
  seenBy?: string[]; // ✅ Track which users have seen this message
  createdAt?: Date;
}

interface MessageCreationAttributes extends Optional<MessageAttributes, "id"> {}

class Message
  extends Model<MessageAttributes, MessageCreationAttributes>
  implements MessageAttributes
{
  public id!: string;
  public senderId!: string;
  public receiverId!: string;
  public messageType!: string;
  public content!: string;
  public seenBy?: string[];
  public createdAt?: Date;
}

Message.init(
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    senderId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: { model: User, key: "id" },
    },
    receiverId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: { model: User, key: "id" },
    },
    messageType: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    content: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    seenBy: {
      type: DataTypes.ARRAY(DataTypes.STRING), // ✅ Store user IDs who have seen the message
      allowNull: true,
      defaultValue: [],
    },
  },
  {
    sequelize,
    modelName: "Message",
    tableName: "messages",
    timestamps: true,
  }
);

export default Message;
