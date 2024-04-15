using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CarCareHub.Services.Migrations
{
    /// <inheritdoc />
    public partial class l : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_placanje_autoservis_dijelovi_Autoservis_AutoservisID",
                table: "placanje_autoservis_dijelovi");

            migrationBuilder.RenameColumn(
                name: "AutoservisID",
                table: "placanje_autoservis_dijelovi",
                newName: "AutoservisId");

            migrationBuilder.RenameIndex(
                name: "IX_placanje_autoservis_dijelovi_AutoservisID",
                table: "placanje_autoservis_dijelovi",
                newName: "IX_placanje_autoservis_dijelovi_AutoservisId");

            migrationBuilder.AddForeignKey(
                name: "FK_placanje_autoservis_dijelovi_Autoservis_AutoservisId",
                table: "placanje_autoservis_dijelovi",
                column: "AutoservisId",
                principalTable: "Autoservis",
                principalColumn: "AutoservisID");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_placanje_autoservis_dijelovi_Autoservis_AutoservisId",
                table: "placanje_autoservis_dijelovi");

            migrationBuilder.RenameColumn(
                name: "AutoservisId",
                table: "placanje_autoservis_dijelovi",
                newName: "AutoservisID");

            migrationBuilder.RenameIndex(
                name: "IX_placanje_autoservis_dijelovi_AutoservisId",
                table: "placanje_autoservis_dijelovi",
                newName: "IX_placanje_autoservis_dijelovi_AutoservisID");

            migrationBuilder.AddForeignKey(
                name: "FK_placanje_autoservis_dijelovi_Autoservis_AutoservisID",
                table: "placanje_autoservis_dijelovi",
                column: "AutoservisID",
                principalTable: "Autoservis",
                principalColumn: "AutoservisID");
        }
    }
}
