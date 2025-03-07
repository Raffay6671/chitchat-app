'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.addColumn('users', 'refreshToken', {
      type: Sequelize.STRING, // You can also use Sequelize.TEXT if tokens are long
      allowNull: true, // Allows users without a refresh token
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.removeColumn('users', 'refreshToken');
  },
};
