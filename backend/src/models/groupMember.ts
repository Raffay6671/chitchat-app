import { DataTypes, Model, Optional } from 'sequelize';
import sequelize from '../config/database';
import Group from './group'; // ✅ Changed to default import
import User from './user'; // ✅ Keep default import

// Interface for GroupMember attributes
interface GroupMemberAttributes {
  groupId: string;
  userId: string;
  joinedAt?: Date;
}

// Optional fields for creation
interface GroupMemberCreationAttributes extends Optional<GroupMemberAttributes, 'joinedAt'> {}

// Define GroupMember model
class GroupMember extends Model<GroupMemberAttributes, GroupMemberCreationAttributes> implements GroupMemberAttributes {
  public groupId!: string;
  public userId!: string;
  public joinedAt?: Date;
}

// Initialize GroupMember schema
GroupMember.init(
  {
    groupId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: Group, // ✅ Correctly referenced with default import
        key: 'id',
      },
      primaryKey: true,
    },
    userId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: User, // ✅ Correctly referenced with default import
        key: 'id',
      },
      primaryKey: true,
    },
    joinedAt: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    },
  },
  {
    sequelize, // ✅ Pass the sequelize instance
    modelName: 'GroupMember', // ✅ Name of the model
    tableName: 'group_members', // ✅ Explicit table name
    underscored: true, // ✅ Use snake_case for consistency
    timestamps: false, // ✅ No automatic timestamps
  }
);

// Export the model
export default GroupMember;
