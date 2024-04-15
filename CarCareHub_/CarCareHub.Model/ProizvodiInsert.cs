using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Model
{
    public class ProizvodiInsert
    {

        public string? Naziv { get; set; }

        [Required]
        [Range(0,10000)]
        public decimal? Cijena { get; set; }

        [MinLength(0)]
        [MaxLength(5)]
        public string? Sifra { get; set; }

        public string? OriginalniBroj { get; set; }

        public string? Model { get; set; }

        public string? Opis { get; set; }

        public int? KategorijaId { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int? FirmaAutoDijelovaID { get; set; }

        public int? ProizvodjacId { get; set; }
        public byte[]? Slika { get; set; }
        public byte[]? SlikaThumb { get; set; }
     
    }
}
