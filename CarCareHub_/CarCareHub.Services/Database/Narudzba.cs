using System;
using System.Collections.Generic;

namespace CarCareHub.Services.Database;

public partial class Narudzba
{
    public int NarudzbaId { get; set; }


    public DateTime? DatumNarudzbe { get; set; }
    public bool Vidljivo { get; set; }
    public DateTime? DatumIsporuke { get; set; }
    public bool? ZavrsenaNarudzba { get; set; } = false; 
    public virtual ICollection<NarudzbaStavka> NarudzbaStavkas { get; set; } = new List<NarudzbaStavka>();
    public int? KlijentId { get; set; }
    public virtual Klijent? Klijent { get; set; }


    public int? AutoservisId { get; set; }
    public virtual Autoservis? Autoservis { get; set; }


    public int? ZaposlenikId { get; set; }
    public virtual Zaposlenik? Zaposlenik { get; set; }

    //dodala
    public decimal? UkupnaCijenaNarudzbe { get; set; }



}
