using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CarCareHub.Services.Migrations
{
    /// <inheritdoc />
    public partial class novosveholhil : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "fk_klijent_chat2",
                table: "Chat_klijent_zaposlenik");

            migrationBuilder.DropForeignKey(
                name: "fk_zaposlenik_chat2",
                table: "Chat_klijent_zaposlenik");

            migrationBuilder.DropTable(
                name: "Poruka");

            migrationBuilder.RenameColumn(
                name: "VrijemeZadnjePoruke",
                table: "Chat_klijent_zaposlenik",
                newName: "VrijemeSlanja");

            migrationBuilder.AlterColumn<int>(
                name: "ZaposlenikId",
                table: "Chat_klijent_zaposlenik",
                type: "int",
                nullable: false,
                defaultValue: 0,
                oldClrType: typeof(int),
                oldType: "int",
                oldNullable: true);

            migrationBuilder.AlterColumn<int>(
                name: "KlijentId",
                table: "Chat_klijent_zaposlenik",
                type: "int",
                nullable: false,
                defaultValue: 0,
                oldClrType: typeof(int),
                oldType: "int",
                oldNullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Poruka",
                table: "Chat_klijent_zaposlenik",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<bool>(
                name: "PoslanoOdKlijenta",
                table: "Chat_klijent_zaposlenik",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddForeignKey(
                name: "fk_klijent_chat2",
                table: "Chat_klijent_zaposlenik",
                column: "KlijentId",
                principalTable: "Klijent",
                principalColumn: "KlijentID",
                onDelete: ReferentialAction.Cascade);

        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "fk_klijent_chat2",
                table: "Chat_klijent_zaposlenik");

            migrationBuilder.DropForeignKey(
                name: "fk_zaposlenik_chat2",
                table: "Chat_klijent_zaposlenik");

            migrationBuilder.DropColumn(
                name: "Poruka",
                table: "Chat_klijent_zaposlenik");

            migrationBuilder.DropColumn(
                name: "PoslanoOdKlijenta",
                table: "Chat_klijent_zaposlenik");

            migrationBuilder.RenameColumn(
                name: "VrijemeSlanja",
                table: "Chat_klijent_zaposlenik",
                newName: "VrijemeZadnjePoruke");

            migrationBuilder.AlterColumn<int>(
                name: "ZaposlenikId",
                table: "Chat_klijent_zaposlenik",
                type: "int",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "int");

            migrationBuilder.AlterColumn<int>(
                name: "KlijentId",
                table: "Chat_klijent_zaposlenik",
                type: "int",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "int");

            migrationBuilder.CreateTable(
                name: "Poruka",
                columns: table => new
                {
                    PorukaId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ChatKlijentZaposlenikId = table.Column<int>(type: "int", nullable: true),
                    ChatKlijentAutoservisId = table.Column<int>(type: "int", nullable: true),
                    Sadrzaj = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    VrijemeSlanja = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Poruka", x => x.PorukaId);
                    table.ForeignKey(
                        name: "FK_Poruka_Chat_klijent_zaposlenik_ChatKlijentZaposlenikId",
                        column: x => x.ChatKlijentZaposlenikId,
                        principalTable: "Chat_klijent_zaposlenik",
                        principalColumn: "ChatKlijentZaposlenikId");
                });

            migrationBuilder.CreateIndex(
                name: "IX_Poruka_ChatKlijentZaposlenikId",
                table: "Poruka",
                column: "ChatKlijentZaposlenikId");

            migrationBuilder.AddForeignKey(
                name: "fk_klijent_chat2",
                table: "Chat_klijent_zaposlenik",
                column: "KlijentId",
                principalTable: "Klijent",
                principalColumn: "KlijentID");

            migrationBuilder.AddForeignKey(
                name: "fk_zaposlenik_chat2",
                table: "Chat_klijent_zaposlenik",
                column: "ZaposlenikId",
                principalTable: "Zaposlenik",
                principalColumn: "ZaposlenikID");
        }
    }
}
