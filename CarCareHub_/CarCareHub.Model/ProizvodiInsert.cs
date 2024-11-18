using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace CarCareHub.Model
{
    public class ProizvodiInsert
    {

        public string? Naziv { get; set; }

        [Required]
        [Range(0,10000)]
        public decimal? Cijena { get; set; }
        public int? Popust { get; set; }

        [NotMapped]
        [JsonIgnore]
        public decimal? CijenaSaPopustom { get; set; }

        [MinLength(0)]
        [MaxLength(5)]
        public string? Sifra { get; set; }

        public string? OriginalniBroj { get; set; }

        public string? ModelProizvoda { get; set; }

        public string? Opis { get; set; }

        public int? KategorijaId { get; set; }
     
        public int? FirmaAutoDijelovaID { get; set; }
        public int? ModelId { get; set; } // Foreign key


        public int? ProizvodjacId { get; set; }
        public byte[]? Slika { get; set; }
        public byte[]? SlikaThumb { get; set; }
     
    }
}
