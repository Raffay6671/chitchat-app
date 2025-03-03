import { DataTypes, Model, Optional, Association } from "sequelize";
import sequelize from "../config/database";
import User from "./user";
import Group from "./group";

interface GroupMessageAttributes {
  id: string;
  senderId: string;
  groupId: string;
  messageType: string;
  content: string;
  createdAt?: Date;
}

interface GroupMessageCreationAttributes
  extends Optional<GroupMessageAttributes, "id"> {}

class GroupMessage
  extends Model<GroupMessageAttributes, GroupMessageCreationAttributes>
  implements GroupMessageAttributes
{
  public id!: string;
  public senderId!: string;
  public groupId!: string;
  public messageType!: string;
  public content!: string;
  public createdAt?: Date;

  // ✅ Add sender as an association
  public declare sender?: User;

  public static associations: {
    sender: Association<GroupMessage, User>;
  };
}

GroupMessage.init(
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
    groupId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: { model: Group, key: "id" },
    },
    messageType: {
      type: DataTypes.STRING,
      allowNull: false,
      defaultValue: "text",
    },
    content: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
  },
  {
    sequelize,
    modelName: "GroupMessage",
    tableName: "group_messages",
    timestamps: true,
  }
);

export default GroupMessage;
