using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CarCareHub.Services.Migrations
{
    /// <inheritdoc />
    public partial class lldf : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "FirmaAutodijelova_Proizvod");

            migrationBuilder.AddColumn<int>(
                name: "FirmaAutodijelovaID",
                table: "Proizvod",
                type: "int",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Proizvod_FirmaAutodijelovaID",
                table: "Proizvod",
                column: "FirmaAutodijelovaID");

            migrationBuilder.AddForeignKey(
                name: "FK__Proizvod__FirmaAutodijelova",
                table: "Proizvod",
                column: "FirmaAutodijelovaID",
                principalTable: "Firma_autodijelova",
                principalColumn: "FirmaID");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK__Proizvod__FirmaAutodijelova",
                table: "Proizvod");

            migrationBuilder.DropIndex(
                name: "IX_Proizvod_FirmaAutodijelovaID",
                table: "Proizvod");

            migrationBuilder.DropColumn(
                name: "FirmaAutodijelovaID",
                table: "Proizvod");

            migrationBuilder.CreateTable(
                name: "FirmaAutodijelova_Proizvod",
                columns: table => new
                {
                    firmaID = table.Column<int>(type: "int", nullable: false),
                    proizvodID = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__FirmaAut__4F1EF5F45990B64A", x => new { x.firmaID, x.proizvodID });
                    table.ForeignKey(
                        name: "FK__FirmaAuto__firma__7F2BE32F",
                        column: x => x.firmaID,
                        principalTable: "Firma_autodijelova",
                        principalColumn: "FirmaID");
                    table.ForeignKey(
                        name: "FK__FirmaAuto__proiz__00200768",
                        column: x => x.proizvodID,
                        principalTable: "Proizvod",
                        principalColumn: "ProizvodID");
                });

            migrationBuilder.CreateIndex(
                name: "IX_FirmaAutodijelova_Proizvod_proizvodID",
                table: "FirmaAutodijelova_Proizvod",
                column: "proizvodID");
        }
    }
}
