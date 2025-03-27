using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CarCareHub.Services.Migrations
{
    /// <inheritdoc />
    public partial class AddedRecommender : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Recommenders",
                columns: table => new
                {
                    RecommenderId = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    proizvodId = table.Column<long>(type: "bigint", nullable: true),
                    prvaPreporukaId = table.Column<long>(type: "bigint", nullable: true),
                    drugaPreporukaId = table.Column<long>(type: "bigint", nullable: true),
                    trecaPreporukaId = table.Column<long>(type: "bigint", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Recommenders", x => x.RecommenderId);
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Recommenders");
        }
    }
}
