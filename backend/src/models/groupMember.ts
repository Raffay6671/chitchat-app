import {
  DataTypes,
  Model,
  Optional,
  BelongsToGetAssociationMixin,
} from "sequelize";
import sequelize from "../config/database";
import Group from "./group";
import User from "./user";

// Interface for GroupMember attributes
interface GroupMemberAttributes {
  groupId: string;
  userId: string;
  joinedAt?: Date;
}

// Optional fields for creation
interface GroupMemberCreationAttributes
  extends Optional<GroupMemberAttributes, "joinedAt"> {}

// Define GroupMember model
class GroupMember
  extends Model<GroupMemberAttributes, GroupMemberCreationAttributes>
  implements GroupMemberAttributes
{
  public groupId!: string;
  public userId!: string;
  public joinedAt?: Date;

  // ✅ Fix: Explicitly define the `user` property for TypeScript
  public user?: User;

  // ✅ Fix: Explicitly add a Sequelize method to fetch the User association
  public getUser!: BelongsToGetAssociationMixin<User>;
}

// Initialize GroupMember schema
GroupMember.init(
  {
    groupId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: Group,
        key: "id",
      },
      primaryKey: true,
    },
    userId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: User,
        key: "id",
      },
      primaryKey: true,
    },
    joinedAt: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    },
  },
  {
    sequelize,
    modelName: "GroupMember",
    tableName: "group_members",
    underscored: true,
    timestamps: false,
  }
);

// ✅ Ensure Sequelize knows the GroupMember has a User
GroupMember.belongsTo(User, { foreignKey: "userId", as: "user" });

export default GroupMember;
