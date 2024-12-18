using System;
using System.Collections.Generic;

namespace CarCareHub.Services.Database;
public partial class NarudzbaStavka
{
    public int NarudzbaStavkaId { get; set; }
  
    public int? ProizvodId { get; set; }

    public virtual Proizvod? Proizvod { get; set; }
    public int? Kolicina { get; set; }
    public int? NarudzbaId { get; set; }
    public virtual Narudzba? Narudzba { get; set; }



}
