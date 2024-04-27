using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CarCareHub.Services.Migrations
{
    /// <inheritdoc />
    public partial class mgjmlkger : Migration
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

            migrationBuilder.DropForeignKey(
                name: "FK_Poruka_Chat_klijent_servis_ChatKlijentServisId",
                table: "Poruka");

            migrationBuilder.DropForeignKey(
                name: "FK_Poruka_Chat_klijent_zaposlenik_ChatKlijentZaposlenikId",
                table: "Poruka");

            migrationBuilder.DropTable(
                name: "Chat_klijent_servis");

            migrationBuilder.DropPrimaryKey(
                name: "PK_drzava",
                table: "Drzava");

            migrationBuilder.DropPrimaryKey(
                name: "pk_chat2",
                table: "Chat_klijent_zaposlenik");

            migrationBuilder.RenameTable(
                name: "Drzava",
                newName: "Drzavas");

            migrationBuilder.RenameTable(
                name: "Chat_klijent_zaposlenik",
                newName: "ChatKlijentZaposleniks");

            migrationBuilder.RenameColumn(
                name: "ChatKlijentServisId",
                table: "Poruka",
                newName: "ChatKlijentAutoservisId");

            migrationBuilder.RenameIndex(
                name: "IX_Poruka_ChatKlijentServisId",
                table: "Poruka",
                newName: "IX_Poruka_ChatKlijentAutoservisId");

            migrationBuilder.RenameColumn(
                name: "DrzavaID",
                table: "Drzavas",
                newName: "DrzavaId");

            migrationBuilder.RenameColumn(
                name: "naziv_drzave",
                table: "Drzavas",
                newName: "NazivDrzave");

            migrationBuilder.RenameIndex(
                name: "IX_Chat_klijent_zaposlenik_ZaposlenikId",
                table: "ChatKlijentZaposleniks",
                newName: "IX_ChatKlijentZaposleniks_ZaposlenikId");

            migrationBuilder.RenameIndex(
                name: "IX_Chat_klijent_zaposlenik_KlijentId",
                table: "ChatKlijentZaposleniks",
                newName: "IX_ChatKlijentZaposleniks_KlijentId");

            migrationBuilder.AlterColumn<string>(
                name: "NazivDrzave",
                table: "Drzavas",
                type: "nvarchar(max)",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "varchar(50)",
                oldUnicode: false,
                oldMaxLength: 50,
                oldNullable: true);

            migrationBuilder.AddColumn<int>(
                name: "AutoservisId",
                table: "ChatKlijentZaposleniks",
                type: "int",
                nullable: true);

            migrationBuilder.AddPrimaryKey(
                name: "PK_Drzavas",
                table: "Drzavas",
                column: "DrzavaId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_ChatKlijentZaposleniks",
                table: "ChatKlijentZaposleniks",
                column: "ChatKlijentZaposlenikId");

            migrationBuilder.CreateTable(
                name: "ChatKlijentAutoserviss",
                columns: table => new
                {
                    ChatKlijentAutoservisId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    VrijemeZadnjePoruke = table.Column<DateTime>(type: "datetime2", nullable: false),
                    KlijentId = table.Column<int>(type: "int", nullable: true),
                    AutoservisId = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ChatKlijentAutoserviss", x => x.ChatKlijentAutoservisId);
                    table.ForeignKey(
                        name: "FK_ChatKlijentAutoserviss_Autoservis_AutoservisId",
                        column: x => x.AutoservisId,
                        principalTable: "Autoservis",
                        principalColumn: "AutoservisID");
                    table.ForeignKey(
                        name: "FK_ChatKlijentAutoserviss_Klijent_KlijentId",
                        column: x => x.KlijentId,
                        principalTable: "Klijent",
                        principalColumn: "KlijentID");
                });

            migrationBuilder.CreateIndex(
                name: "IX_ChatKlijentZaposleniks_AutoservisId",
                table: "ChatKlijentZaposleniks",
                column: "AutoservisId");

            migrationBuilder.CreateIndex(
                name: "IX_ChatKlijentAutoserviss_AutoservisId",
                table: "ChatKlijentAutoserviss",
                column: "AutoservisId");

            migrationBuilder.CreateIndex(
                name: "IX_ChatKlijentAutoserviss_KlijentId",
                table: "ChatKlijentAutoserviss",
                column: "KlijentId");

            migrationBuilder.AddForeignKey(
                name: "FK_ChatKlijentZaposleniks_Autoservis_AutoservisId",
                table: "ChatKlijentZaposleniks",
                column: "AutoservisId",
                principalTable: "Autoservis",
                principalColumn: "AutoservisID");

            migrationBuilder.AddForeignKey(
                name: "FK_ChatKlijentZaposleniks_Klijent_KlijentId",
                table: "ChatKlijentZaposleniks",
                column: "KlijentId",
                principalTable: "Klijent",
                principalColumn: "KlijentID");

            migrationBuilder.AddForeignKey(
                name: "FK_ChatKlijentZaposleniks_Zaposlenik_ZaposlenikId",
                table: "ChatKlijentZaposleniks",
                column: "ZaposlenikId",
                principalTable: "Zaposlenik",
                principalColumn: "ZaposlenikID");

            migrationBuilder.AddForeignKey(
                name: "FK_Poruka_ChatKlijentAutoserviss_ChatKlijentAutoservisId",
                table: "Poruka",
                column: "ChatKlijentAutoservisId",
                principalTable: "ChatKlijentAutoserviss",
                principalColumn: "ChatKlijentAutoservisId");

            migrationBuilder.AddForeignKey(
                name: "FK_Poruka_ChatKlijentZaposleniks_ChatKlijentZaposlenikId",
                table: "Poruka",
                column: "ChatKlijentZaposlenikId",
                principalTable: "ChatKlijentZaposleniks",
                principalColumn: "ChatKlijentZaposlenikId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_ChatKlijentZaposleniks_Autoservis_AutoservisId",
                table: "ChatKlijentZaposleniks");

            migrationBuilder.DropForeignKey(
                name: "FK_ChatKlijentZaposleniks_Klijent_KlijentId",
                table: "ChatKlijentZaposleniks");

            migrationBuilder.DropForeignKey(
                name: "FK_ChatKlijentZaposleniks_Zaposlenik_ZaposlenikId",
                table: "ChatKlijentZaposleniks");

            migrationBuilder.DropForeignKey(
                name: "FK_Poruka_ChatKlijentAutoserviss_ChatKlijentAutoservisId",
                table: "Poruka");

            migrationBuilder.DropForeignKey(
                name: "FK_Poruka_ChatKlijentZaposleniks_ChatKlijentZaposlenikId",
                table: "Poruka");

            migrationBuilder.DropTable(
                name: "ChatKlijentAutoserviss");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Drzavas",
                table: "Drzavas");

            migrationBuilder.DropPrimaryKey(
                name: "PK_ChatKlijentZaposleniks",
                table: "ChatKlijentZaposleniks");

            migrationBuilder.DropIndex(
                name: "IX_ChatKlijentZaposleniks_AutoservisId",
                table: "ChatKlijentZaposleniks");

            migrationBuilder.DropColumn(
                name: "AutoservisId",
                table: "ChatKlijentZaposleniks");

            migrationBuilder.RenameTable(
                name: "Drzavas",
                newName: "Drzava");

            migrationBuilder.RenameTable(
                name: "ChatKlijentZaposleniks",
                newName: "Chat_klijent_zaposlenik");

            migrationBuilder.RenameColumn(
                name: "ChatKlijentAutoservisId",
                table: "Poruka",
                newName: "ChatKlijentServisId");

            migrationBuilder.RenameIndex(
                name: "IX_Poruka_ChatKlijentAutoservisId",
                table: "Poruka",
                newName: "IX_Poruka_ChatKlijentServisId");

            migrationBuilder.RenameColumn(
                name: "DrzavaId",
                table: "Drzava",
                newName: "DrzavaID");

            migrationBuilder.RenameColumn(
                name: "NazivDrzave",
                table: "Drzava",
                newName: "naziv_drzave");

            migrationBuilder.RenameIndex(
                name: "IX_ChatKlijentZaposleniks_ZaposlenikId",
                table: "Chat_klijent_zaposlenik",
                newName: "IX_Chat_klijent_zaposlenik_ZaposlenikId");

            migrationBuilder.RenameIndex(
                name: "IX_ChatKlijentZaposleniks_KlijentId",
                table: "Chat_klijent_zaposlenik",
                newName: "IX_Chat_klijent_zaposlenik_KlijentId");

            migrationBuilder.AlterColumn<string>(
                name: "naziv_drzave",
                table: "Drzava",
                type: "varchar(50)",
                unicode: false,
                maxLength: 50,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(max)",
                oldNullable: true);

            migrationBuilder.AddPrimaryKey(
                name: "PK_drzava",
                table: "Drzava",
                column: "DrzavaID");

            migrationBuilder.AddPrimaryKey(
                name: "pk_chat2",
                table: "Chat_klijent_zaposlenik",
                column: "ChatKlijentZaposlenikId");

            migrationBuilder.CreateTable(
                name: "Chat_klijent_servis",
                columns: table => new
                {
                    ChatKlijentServisId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    AutoservisId = table.Column<int>(type: "int", nullable: true),
                    KlijentId = table.Column<int>(type: "int", nullable: true),
                    VrijemeZadnjePoruke = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_chat", x => x.ChatKlijentServisId);
                    table.ForeignKey(
                        name: "fk_autoservis_chat",
                        column: x => x.AutoservisId,
                        principalTable: "Autoservis",
                        principalColumn: "AutoservisID");
                    table.ForeignKey(
                        name: "fk_klijent_chat",
                        column: x => x.KlijentId,
                        principalTable: "Klijent",
                        principalColumn: "KlijentID");
                });

            migrationBuilder.CreateIndex(
                name: "IX_Chat_klijent_servis_AutoservisId",
                table: "Chat_klijent_servis",
                column: "AutoservisId");

            migrationBuilder.CreateIndex(
                name: "IX_Chat_klijent_servis_KlijentId",
                table: "Chat_klijent_servis",
                column: "KlijentId");

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

            migrationBuilder.AddForeignKey(
                name: "FK_Poruka_Chat_klijent_servis_ChatKlijentServisId",
                table: "Poruka",
                column: "ChatKlijentServisId",
                principalTable: "Chat_klijent_servis",
                principalColumn: "ChatKlijentServisId");

            migrationBuilder.AddForeignKey(
                name: "FK_Poruka_Chat_klijent_zaposlenik_ChatKlijentZaposlenikId",
                table: "Poruka",
                column: "ChatKlijentZaposlenikId",
                principalTable: "Chat_klijent_zaposlenik",
                principalColumn: "ChatKlijentZaposlenikId");
        }
    }
}
