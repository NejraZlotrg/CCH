using System;
using System.Collections.Generic;

namespace CarCareHub.Services.Database;
public partial class NarudzbaStavka
{
    public int NarudzbaStavkaId { get; set; }

 
  
    public int? KorpaId { get; set; }

    public virtual Korpa? Korpa { get; set; }
    public int? NarudzbaId { get; set; }

    public virtual Narudzba? Narudzba { get; set; }



}
