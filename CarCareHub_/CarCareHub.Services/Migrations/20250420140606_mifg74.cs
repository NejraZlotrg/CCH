using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CarCareHub.Services.Migrations
{
    /// <inheritdoc />
    public partial class mifg74 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Model_Godiste_GodisteId",
                table: "Model");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Godiste",
                table: "Godiste");

            migrationBuilder.RenameTable(
                name: "Godiste",
                newName: "Godistes");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Godistes",
                table: "Godistes",
                column: "GodisteId");

            migrationBuilder.AddForeignKey(
                name: "FK_Model_Godistes_GodisteId",
                table: "Model",
                column: "GodisteId",
                principalTable: "Godistes",
                principalColumn: "GodisteId",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Model_Godistes_GodisteId",
                table: "Model");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Godistes",
                table: "Godistes");

            migrationBuilder.RenameTable(
                name: "Godistes",
                newName: "Godiste");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Godiste",
                table: "Godiste",
                column: "GodisteId");

            migrationBuilder.AddForeignKey(
                name: "FK_Model_Godiste_GodisteId",
                table: "Model",
                column: "GodisteId",
                principalTable: "Godiste",
                principalColumn: "GodisteId",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
