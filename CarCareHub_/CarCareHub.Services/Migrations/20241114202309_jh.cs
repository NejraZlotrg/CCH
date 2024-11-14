using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CarCareHub.Services.Migrations
{
    /// <inheritdoc />
    public partial class jh : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Godiste_Model_ModelId",
                table: "Godiste");

            migrationBuilder.DropIndex(
                name: "IX_Godiste_ModelId",
                table: "Godiste");

            migrationBuilder.DropColumn(
                name: "ModelId",
                table: "Godiste");

            migrationBuilder.AddColumn<int>(
                name: "GodisteId",
                table: "Model",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateIndex(
                name: "IX_Model_GodisteId",
                table: "Model",
                column: "GodisteId");

            migrationBuilder.AddForeignKey(
                name: "FK_Model_Godiste_GodisteId",
                table: "Model",
                column: "GodisteId",
                principalTable: "Godiste",
                principalColumn: "GodisteId",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Model_Godiste_GodisteId",
                table: "Model");

            migrationBuilder.DropIndex(
                name: "IX_Model_GodisteId",
                table: "Model");

            migrationBuilder.DropColumn(
                name: "GodisteId",
                table: "Model");

            migrationBuilder.AddColumn<int>(
                name: "ModelId",
                table: "Godiste",
                type: "int",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Godiste_ModelId",
                table: "Godiste",
                column: "ModelId");

            migrationBuilder.AddForeignKey(
                name: "FK_Godiste_Model_ModelId",
                table: "Godiste",
                column: "ModelId",
                principalTable: "Model",
                principalColumn: "ModelId");
        }
    }
}
