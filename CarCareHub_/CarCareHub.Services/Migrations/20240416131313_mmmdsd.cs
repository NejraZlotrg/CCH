using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CarCareHub.Services.Migrations
{
    /// <inheritdoc />
    public partial class mmmdsd : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "datum",
                table: "Chat_klijent_zaposlenik");

            migrationBuilder.DropColumn(
                name: "sadrzaj",
                table: "Chat_klijent_zaposlenik");

            migrationBuilder.DropColumn(
                name: "datum",
                table: "Chat_klijent_servis");

            migrationBuilder.DropColumn(
                name: "sadrzaj",
                table: "Chat_klijent_servis");

            migrationBuilder.RenameColumn(
                name: "ChatKlijentZaposlenikID",
                table: "Chat_klijent_zaposlenik",
                newName: "ChatKlijentZaposlenikId");

            migrationBuilder.RenameColumn(
                name: "zaposlenik_id",
                table: "Chat_klijent_zaposlenik",
                newName: "ZaposlenikId");

            migrationBuilder.RenameColumn(
                name: "klijent_id",
                table: "Chat_klijent_zaposlenik",
                newName: "KlijentId");

            migrationBuilder.RenameIndex(
                name: "IX_Chat_klijent_zaposlenik_zaposlenik_id",
                table: "Chat_klijent_zaposlenik",
                newName: "IX_Chat_klijent_zaposlenik_ZaposlenikId");

            migrationBuilder.RenameIndex(
                name: "IX_Chat_klijent_zaposlenik_klijent_id",
                table: "Chat_klijent_zaposlenik",
                newName: "IX_Chat_klijent_zaposlenik_KlijentId");

            migrationBuilder.RenameColumn(
                name: "ChatKlijentServisID",
                table: "Chat_klijent_servis",
                newName: "ChatKlijentServisId");

            migrationBuilder.RenameColumn(
                name: "klijent_id",
                table: "Chat_klijent_servis",
                newName: "KlijentId");

            migrationBuilder.RenameColumn(
                name: "autoservis_id",
                table: "Chat_klijent_servis",
                newName: "AutoservisId");

            migrationBuilder.RenameIndex(
                name: "IX_Chat_klijent_servis_klijent_id",
                table: "Chat_klijent_servis",
                newName: "IX_Chat_klijent_servis_KlijentId");

            migrationBuilder.RenameIndex(
                name: "IX_Chat_klijent_servis_autoservis_id",
                table: "Chat_klijent_servis",
                newName: "IX_Chat_klijent_servis_AutoservisId");

            migrationBuilder.AddColumn<DateTime>(
                name: "VrijemeZadnjePoruke",
                table: "Chat_klijent_zaposlenik",
                type: "datetime2",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<DateTime>(
                name: "VrijemeZadnjePoruke",
                table: "Chat_klijent_servis",
                type: "datetime2",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.CreateTable(
                name: "Poruka",
                columns: table => new
                {
                    PorukaId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Sadrzaj = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    VrijemeSlanja = table.Column<DateTime>(type: "datetime2", nullable: false),
                    ChatKlijentAutoservisId = table.Column<int>(type: "int", nullable: true),
                    ChatKlijentServisId = table.Column<int>(type: "int", nullable: true),
                    ChatKlijentZaposlenikId = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Poruka", x => x.PorukaId);
                    table.ForeignKey(
                        name: "FK_Poruka_Chat_klijent_servis_ChatKlijentServisId",
                        column: x => x.ChatKlijentServisId,
                        principalTable: "Chat_klijent_servis",
                        principalColumn: "ChatKlijentServisId");
                    table.ForeignKey(
                        name: "FK_Poruka_Chat_klijent_zaposlenik_ChatKlijentZaposlenikId",
                        column: x => x.ChatKlijentZaposlenikId,
                        principalTable: "Chat_klijent_zaposlenik",
                        principalColumn: "ChatKlijentZaposlenikId");
                });

            migrationBuilder.CreateIndex(
                name: "IX_Poruka_ChatKlijentServisId",
                table: "Poruka",
                column: "ChatKlijentServisId");

            migrationBuilder.CreateIndex(
                name: "IX_Poruka_ChatKlijentZaposlenikId",
                table: "Poruka",
                column: "ChatKlijentZaposlenikId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Poruka");

            migrationBuilder.DropColumn(
                name: "VrijemeZadnjePoruke",
                table: "Chat_klijent_zaposlenik");

            migrationBuilder.DropColumn(
                name: "VrijemeZadnjePoruke",
                table: "Chat_klijent_servis");

            migrationBuilder.RenameColumn(
                name: "ChatKlijentZaposlenikId",
                table: "Chat_klijent_zaposlenik",
                newName: "ChatKlijentZaposlenikID");

            migrationBuilder.RenameColumn(
                name: "ZaposlenikId",
                table: "Chat_klijent_zaposlenik",
                newName: "zaposlenik_id");

            migrationBuilder.RenameColumn(
                name: "KlijentId",
                table: "Chat_klijent_zaposlenik",
                newName: "klijent_id");

            migrationBuilder.RenameIndex(
                name: "IX_Chat_klijent_zaposlenik_ZaposlenikId",
                table: "Chat_klijent_zaposlenik",
                newName: "IX_Chat_klijent_zaposlenik_zaposlenik_id");

            migrationBuilder.RenameIndex(
                name: "IX_Chat_klijent_zaposlenik_KlijentId",
                table: "Chat_klijent_zaposlenik",
                newName: "IX_Chat_klijent_zaposlenik_klijent_id");

            migrationBuilder.RenameColumn(
                name: "ChatKlijentServisId",
                table: "Chat_klijent_servis",
                newName: "ChatKlijentServisID");

            migrationBuilder.RenameColumn(
                name: "KlijentId",
                table: "Chat_klijent_servis",
                newName: "klijent_id");

            migrationBuilder.RenameColumn(
                name: "AutoservisId",
                table: "Chat_klijent_servis",
                newName: "autoservis_id");

            migrationBuilder.RenameIndex(
                name: "IX_Chat_klijent_servis_KlijentId",
                table: "Chat_klijent_servis",
                newName: "IX_Chat_klijent_servis_klijent_id");

            migrationBuilder.RenameIndex(
                name: "IX_Chat_klijent_servis_AutoservisId",
                table: "Chat_klijent_servis",
                newName: "IX_Chat_klijent_servis_autoservis_id");

            migrationBuilder.AddColumn<DateTime>(
                name: "datum",
                table: "Chat_klijent_zaposlenik",
                type: "datetime",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "sadrzaj",
                table: "Chat_klijent_zaposlenik",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "datum",
                table: "Chat_klijent_servis",
                type: "datetime",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "sadrzaj",
                table: "Chat_klijent_servis",
                type: "text",
                nullable: true);
        }
    }
}
