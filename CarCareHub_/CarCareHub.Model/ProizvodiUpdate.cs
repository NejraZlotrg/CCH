using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Model
{
    public class ProizvodiUpdate
    {
       

        public string? Naziv { get; set; }

        public decimal? Cijena { get; set; }

       // public string? Sifra { get; set; }

        //public string? OriginalniBroj { get; set; }

        public string? Model { get; set; }

        public string? Opis { get; set; }

        //public int? KategorijaId { get; set; }

       // public int? ProizvodjacId { get; set; }
        public byte[]? Slika { get; set; }
        public byte[]? SlikaThumb { get; set; }
      
    }
}
