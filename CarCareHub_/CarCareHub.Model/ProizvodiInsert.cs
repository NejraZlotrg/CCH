using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace CarCareHub.Model
{
    public class ProizvodiInsert
    {
        [Required(ErrorMessage = "Naziv proizvoda je obavezan.")]
        [StringLength(100, MinimumLength = 2, ErrorMessage = "Naziv mora imati između 2 i 100 karaktera.")]
        public string? Naziv { get; set; }

        [Required(ErrorMessage = "Cijena je obavezna.")]
        [Range(0.01, 10000, ErrorMessage = "Cijena mora biti između 0.01 i 10,000.")]
        public decimal? Cijena { get; set; }

        [Range(0, 100, ErrorMessage = "Popust mora biti između 0 i 100%.")]
        public int? Popust { get; set; }

        [NotMapped]
        [JsonIgnore]
        public decimal? CijenaSaPopustom { get; set; }

        [NotMapped]
        [JsonIgnore]
        public decimal? CijenaSaPopustomZaAutoservis { get; set; }

        [StringLength(5, ErrorMessage = "Šifra može imati maksimalno 5 karaktera.")]
        public string? Sifra { get; set; }

        [StringLength(50, ErrorMessage = "Originalni broj može imati najviše 50 karaktera.")]
        public string? OriginalniBroj { get; set; }

        public bool? Vidljivo { get; set; } = true;

        [StringLength(1000, ErrorMessage = "Opis može imati najviše 1000 karaktera.")]
        public string? Opis { get; set; }

        [Required(ErrorMessage = "Kategorija je obavezna.")]
        public int? KategorijaId { get; set; }

        [Required(ErrorMessage = "Firma autodijelova je obavezna.")]
        public int? FirmaAutoDijelovaID { get; set; }

        [Required(ErrorMessage = "Model vozila je obavezan.")]
        public int? ModelId { get; set; }

        [Required(ErrorMessage = "Proizvođač je obavezan.")]
        public int? ProizvodjacId { get; set; }

        public byte[]? Slika { get; set; }
    }
}
