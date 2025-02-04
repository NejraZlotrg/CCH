using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CarCareHub.Services.Migrations
{
    /// <inheritdoc />
    public partial class bhgg : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "Vidljivo",
                table: "Zaposlenik",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "Vidljivo",
                table: "Vozilos",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "Vidljivo",
                table: "Usluge",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "Vidljivo",
                table: "Uloge",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "Vidljivo",
                table: "Proizvodjac",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "Vidljivo",
                table: "Proizvod",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "Vidljivo",
                table: "placanje_autoservis_dijelovi",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "Vidljivo",
                table: "NarudzbaStavkas",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "Vidljivo",
                table: "Narudzbas",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "Vidljivo",
                table: "Model",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "Vidljivo",
                table: "Korpas",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "Vidljivo",
                table: "Klijent",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "Vidljivo",
                table: "Kategorija",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "Vidljivo",
                table: "Izvjestaj",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "Vidljivo",
                table: "Grad",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "Vidljivo",
                table: "Godiste",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "Vidljivo",
                table: "Firma_autodijelova",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "Vidljivo",
                table: "Drzava",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "Vidljivo",
                table: "ChatAutoservisKlijents",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "Vidljivo",
                table: "Chat_klijent_zaposlenik",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "Vidljivo",
                table: "BPAutodijeloviAutoservis",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "Vidljivo",
                table: "Autoservis",
                type: "bit",
                nullable: false,
                defaultValue: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Vidljivo",
                table: "Zaposlenik");

            migrationBuilder.DropColumn(
                name: "Vidljivo",
                table: "Vozilos");

            migrationBuilder.DropColumn(
                name: "Vidljivo",
                table: "Usluge");

            migrationBuilder.DropColumn(
                name: "Vidljivo",
                table: "Uloge");

            migrationBuilder.DropColumn(
                name: "Vidljivo",
                table: "Proizvodjac");

            migrationBuilder.DropColumn(
                name: "Vidljivo",
                table: "Proizvod");

            migrationBuilder.DropColumn(
                name: "Vidljivo",
                table: "placanje_autoservis_dijelovi");

            migrationBuilder.DropColumn(
                name: "Vidljivo",
                table: "NarudzbaStavkas");

            migrationBuilder.DropColumn(
                name: "Vidljivo",
                table: "Narudzbas");

            migrationBuilder.DropColumn(
                name: "Vidljivo",
                table: "Model");

            migrationBuilder.DropColumn(
                name: "Vidljivo",
                table: "Korpas");

            migrationBuilder.DropColumn(
                name: "Vidljivo",
                table: "Klijent");

            migrationBuilder.DropColumn(
                name: "Vidljivo",
                table: "Kategorija");

            migrationBuilder.DropColumn(
                name: "Vidljivo",
                table: "Izvjestaj");

            migrationBuilder.DropColumn(
                name: "Vidljivo",
                table: "Grad");

            migrationBuilder.DropColumn(
                name: "Vidljivo",
                table: "Godiste");

            migrationBuilder.DropColumn(
                name: "Vidljivo",
                table: "Firma_autodijelova");

            migrationBuilder.DropColumn(
                name: "Vidljivo",
                table: "Drzava");

            migrationBuilder.DropColumn(
                name: "Vidljivo",
                table: "ChatAutoservisKlijents");

            migrationBuilder.DropColumn(
                name: "Vidljivo",
                table: "Chat_klijent_zaposlenik");

            migrationBuilder.DropColumn(
                name: "Vidljivo",
                table: "BPAutodijeloviAutoservis");

            migrationBuilder.DropColumn(
                name: "Vidljivo",
                table: "Autoservis");
        }
    }
}
