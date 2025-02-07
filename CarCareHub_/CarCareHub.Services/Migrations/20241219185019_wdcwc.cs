using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CarCareHub.Services.Migrations
{
    /// <inheritdoc />
    public partial class wdcwc : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_ChatAUtoservisKlijents_Autoservis_AutoservisId",
                table: "ChatAUtoservisKlijents");

            migrationBuilder.DropForeignKey(
                name: "FK_ChatAUtoservisKlijents_Klijent_KlijentId",
                table: "ChatAUtoservisKlijents");

            migrationBuilder.DropPrimaryKey(
                name: "PK_ChatAUtoservisKlijents",
                table: "ChatAUtoservisKlijents");

            migrationBuilder.RenameTable(
                name: "ChatAUtoservisKlijents",
                newName: "ChatAutoservisKlijents");

            migrationBuilder.RenameIndex(
                name: "IX_ChatAUtoservisKlijents_KlijentId",
                table: "ChatAutoservisKlijents",
                newName: "IX_ChatAutoservisKlijents_KlijentId");

            migrationBuilder.RenameIndex(
                name: "IX_ChatAUtoservisKlijents_AutoservisId",
                table: "ChatAutoservisKlijents",
                newName: "IX_ChatAutoservisKlijents_AutoservisId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_ChatAutoservisKlijents",
                table: "ChatAutoservisKlijents",
                column: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_ChatAutoservisKlijents_Autoservis_AutoservisId",
                table: "ChatAutoservisKlijents",
                column: "AutoservisId",
                principalTable: "Autoservis",
                principalColumn: "AutoservisID",
                onDelete: ReferentialAction.NoAction);

            migrationBuilder.AddForeignKey(
                name: "FK_ChatAutoservisKlijents_Klijent_KlijentId",
                table: "ChatAutoservisKlijents",
                column: "KlijentId",
                principalTable: "Klijent",
                principalColumn: "KlijentID",
                onDelete: ReferentialAction.NoAction);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_ChatAutoservisKlijents_Autoservis_AutoservisId",
                table: "ChatAutoservisKlijents");

            migrationBuilder.DropForeignKey(
                name: "FK_ChatAutoservisKlijents_Klijent_KlijentId",
                table: "ChatAutoservisKlijents");

            migrationBuilder.DropPrimaryKey(
                name: "PK_ChatAutoservisKlijents",
                table: "ChatAutoservisKlijents");

            migrationBuilder.RenameTable(
                name: "ChatAutoservisKlijents",
                newName: "ChatAUtoservisKlijents");

            migrationBuilder.RenameIndex(
                name: "IX_ChatAutoservisKlijents_KlijentId",
                table: "ChatAUtoservisKlijents",
                newName: "IX_ChatAUtoservisKlijents_KlijentId");

            migrationBuilder.RenameIndex(
                name: "IX_ChatAutoservisKlijents_AutoservisId",
                table: "ChatAUtoservisKlijents",
                newName: "IX_ChatAUtoservisKlijents_AutoservisId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_ChatAUtoservisKlijents",
                table: "ChatAUtoservisKlijents",
                column: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_ChatAUtoservisKlijents_Autoservis_AutoservisId",
                table: "ChatAUtoservisKlijents",
                column: "AutoservisId",
                principalTable: "Autoservis",
                principalColumn: "AutoservisID",
                onDelete: ReferentialAction.NoAction);

            migrationBuilder.AddForeignKey(
                name: "FK_ChatAUtoservisKlijents_Klijent_KlijentId",
                table: "ChatAUtoservisKlijents",
                column: "KlijentId",
                principalTable: "Klijent",
                principalColumn: "KlijentID",
                onDelete: ReferentialAction.NoAction);
        }
    }
}
