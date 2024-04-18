using System;
using System.Collections.Generic;

namespace CarCareHub.Services.Database;

public partial class NarudzbaStavka
{
    public int NarudzbaStavkaId { get; set; }

    public int? ProizvodId { get; set; }

    public int? Kolicina { get; set; }

    public decimal? UkupnaCijenaProizvoda { get; set; }

    //public virtual ICollection<Narudzba> Narudzbas { get; set; } = new List<Narudzba>();

    public virtual Proizvod? Proizvod { get; set; }
    //dodala
    public virtual Narudzba? Narudzba { get; set; }
    public int? NarudzbaId { get; set; }

}
