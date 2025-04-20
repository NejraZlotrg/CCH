using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CarCareHub.Services.Migrations
{
    /// <inheritdoc />
    public partial class seed : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Model_Godistes_GodisteId",
                table: "Model");

            migrationBuilder.DropForeignKey(
                name: "FK_Model_Vozilos_VoziloId",
                table: "Model");

            migrationBuilder.DropForeignKey(
                name: "FK_Proizvod_Model_ModelId",
                table: "Proizvod");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Model",
                table: "Model");

            migrationBuilder.RenameTable(
                name: "Model",
                newName: "Models");

            migrationBuilder.RenameIndex(
                name: "IX_Model_VoziloId",
                table: "Models",
                newName: "IX_Models_VoziloId");

            migrationBuilder.RenameIndex(
                name: "IX_Model_GodisteId",
                table: "Models",
                newName: "IX_Models_GodisteId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Models",
                table: "Models",
                column: "ModelId");

            migrationBuilder.AddForeignKey(
                name: "FK_Models_Godistes_GodisteId",
                table: "Models",
                column: "GodisteId",
                principalTable: "Godistes",
                principalColumn: "GodisteId",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Models_Vozilos_VoziloId",
                table: "Models",
                column: "VoziloId",
                principalTable: "Vozilos",
                principalColumn: "VoziloId",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Proizvod_Models_ModelId",
                table: "Proizvod",
                column: "ModelId",
                principalTable: "Models",
                principalColumn: "ModelId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Models_Godistes_GodisteId",
                table: "Models");

            migrationBuilder.DropForeignKey(
                name: "FK_Models_Vozilos_VoziloId",
                table: "Models");

            migrationBuilder.DropForeignKey(
                name: "FK_Proizvod_Models_ModelId",
                table: "Proizvod");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Models",
                table: "Models");

            migrationBuilder.RenameTable(
                name: "Models",
                newName: "Model");

            migrationBuilder.RenameIndex(
                name: "IX_Models_VoziloId",
                table: "Model",
                newName: "IX_Model_VoziloId");

            migrationBuilder.RenameIndex(
                name: "IX_Models_GodisteId",
                table: "Model",
                newName: "IX_Model_GodisteId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Model",
                table: "Model",
                column: "ModelId");

            migrationBuilder.AddForeignKey(
                name: "FK_Model_Godistes_GodisteId",
                table: "Model",
                column: "GodisteId",
                principalTable: "Godistes",
                principalColumn: "GodisteId",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Model_Vozilos_VoziloId",
                table: "Model",
                column: "VoziloId",
                principalTable: "Vozilos",
                principalColumn: "VoziloId",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Proizvod_Model_ModelId",
                table: "Proizvod",
                column: "ModelId",
                principalTable: "Model",
                principalColumn: "ModelId");
        }
    }
}
