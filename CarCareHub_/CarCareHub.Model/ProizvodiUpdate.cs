using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace CarCareHub.Model
{
    public class ProizvodiUpdate
    {
       

        public string? Naziv { get; set; }

        public decimal? Cijena { get; set; }
        public bool? Vidljivo { get; set; }

        public int? Popust { get; set; }

        [NotMapped]
        [JsonIgnore]
        public decimal? CijenaSaPopustom { get; set; }




        public string? Sifra { get; set; }

        public string? OriginalniBroj { get; set; }

        public string? ModelProizvoda { get; set; }

        public string? Opis { get; set; }

        public int? KategorijaId { get; set; }

        public int? ProizvodjacId { get; set; }
        public int? firmaAutodijelovaID { get; set; }
        public int? ModelId { get; set; } // Foreign key
        [NotMapped]
        [JsonIgnore]
        public decimal? CijenaSaPopustomZaAutoservis { get; set; }

        public byte[]? Slika { get; set; }
        public byte[]? SlikaThumb { get; set; }
      
    }
}
