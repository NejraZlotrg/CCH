using System;
using System.Collections.Generic;

namespace CarCareHub.Services.Database;

public partial class Narudzba
{
    public int NarudzbaId { get; set; }

   // public int? NarudzbaStavkeId { get; set; }

    public DateTime? DatumNarudzbe { get; set; }

    public DateTime? DatumIsporuke { get; set; }
    public bool? ZavrsenaNarudzba { get; set; }

    //dodala
    public decimal? UkupnaCijenaNarudzbe { get; set; }


    public virtual ICollection<NarudzbaStavka> NarudzbaStavkas { get; set; } = new List<NarudzbaStavka>();
}
