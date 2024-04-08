using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Model
{
    public class Proizvod
    {
        public int ProizvodId { get; set; }

        public string? Naziv { get; set; }

        public decimal? Cijena { get; set; }

        public string? Sifra { get; set; }

        public string? OriginalniBroj { get; set; }

        public string? Model { get; set; }

        public string? Opis { get; set; }

        public int? KategorijaId { get; set; }
        public virtual Kategorija Kategorija { get; set; }


        public int? ProizvodjacId { get; set; }
        public virtual Proizvodjac Proizvodjac { get; set; }

        public byte[]? Slika { get; set; }
        public byte[]? SlikaThumb { get; set; }
        public string StateMachine { get; set; }

    }
}