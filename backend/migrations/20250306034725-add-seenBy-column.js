"use strict";

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.addColumn("messages", "seenBy", {
      type: Sequelize.ARRAY(Sequelize.STRING), // ✅ Using ARRAY for PostgreSQL
      allowNull: true,
      defaultValue: [],
    });

    await queryInterface.addColumn("group_messages", "seenBy", {
      type: Sequelize.ARRAY(Sequelize.STRING), // ✅ Using ARRAY for PostgreSQL
      allowNull: true,
      defaultValue: [],
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.removeColumn("messages", "seenBy");
    await queryInterface.removeColumn("group_messages", "seenBy");
  },
};
