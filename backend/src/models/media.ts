import { DataTypes, Model, Optional } from 'sequelize';
import sequelize from '../config/database';
import User from './user';
import Message from './message';

// Define the attributes of the Media model
interface MediaAttributes {
  id: string;
  userId: string;
  messageId: string;
  mediaType: string;
  mediaUrl: string;
  createdAt?: Date;
  updatedAt?: Date;
}

interface MediaCreationAttributes extends Optional<MediaAttributes, 'id'> {}

class Media extends Model<MediaAttributes, MediaCreationAttributes> implements MediaAttributes {
  public id!: string;
  public userId!: string;
  public messageId!: string;
  public mediaType!: string;
  public mediaUrl!: string;
  public createdAt?: Date;
  public updatedAt?: Date;
}

// Initialize the Media model
Media.init(
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    userId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: User,
        key: 'id',
      },
    },
    messageId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: Message,
        key: 'id',
      },
    },
    mediaType: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    mediaUrl: {
      type: DataTypes.STRING,
      allowNull: false,
    },
  },
  {
    sequelize,
    modelName: 'Media',
    underscored: true,
    timestamps: true,
  }
);

export default Media;