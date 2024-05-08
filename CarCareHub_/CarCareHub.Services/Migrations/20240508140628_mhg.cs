using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CarCareHub.Services.Migrations
{
    /// <inheritdoc />
    public partial class mhg : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "BPAutodijeloviAutoservis",
                columns: table => new
                {
                    BPAutodijeloviAutoservisId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    FirmaAutodijelovaID = table.Column<int>(type: "int", nullable: true),
                    AutoservisId = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_BPAutodijeloviAutoservis", x => x.BPAutodijeloviAutoservisId);
                    table.ForeignKey(
                        name: "FK_BPAutodijeloviAutoservis_Autoservis_AutoservisId",
                        column: x => x.AutoservisId,
                        principalTable: "Autoservis",
                        principalColumn: "AutoservisID");
                    table.ForeignKey(
                        name: "FK_BPAutodijeloviAutoservis_Firma_autodijelova_FirmaAutodijelovaID",
                        column: x => x.FirmaAutodijelovaID,
                        principalTable: "Firma_autodijelova",
                        principalColumn: "FirmaID");
                });

            migrationBuilder.CreateIndex(
                name: "IX_BPAutodijeloviAutoservis_AutoservisId",
                table: "BPAutodijeloviAutoservis",
                column: "AutoservisId");

            migrationBuilder.CreateIndex(
                name: "IX_BPAutodijeloviAutoservis_FirmaAutodijelovaID",
                table: "BPAutodijeloviAutoservis",
                column: "FirmaAutodijelovaID");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "BPAutodijeloviAutoservis");
        }
    }
}
