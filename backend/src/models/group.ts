import { DataTypes, Model, Optional } from "sequelize";
import sequelize from "../config/database";

interface GroupAttributes {
  id: string;
  name: string;
  createdAt?: Date;
  updatedAt?: Date;
}

interface GroupCreationAttributes extends Optional<GroupAttributes, "id"> {}

class Group
  extends Model<GroupAttributes, GroupCreationAttributes>
  implements GroupAttributes
{
  public id!: string;
  public name!: string;
  public createdAt?: Date;
  public updatedAt?: Date;
}

Group.init(
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    name: {
      type: DataTypes.STRING,
      allowNull: false,
    },
  },
  {
    sequelize,
    modelName: "Group",
    underscored: true,
    timestamps: true,
  }
);

// ✅ Add both default and named exports
export { Group };
export default Group;
