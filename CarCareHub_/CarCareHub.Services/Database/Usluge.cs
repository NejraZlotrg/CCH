using System;
using System.Collections.Generic;

namespace CarCareHub.Services.Database;

public partial class Usluge
{
    public int UslugeId { get; set; }

    public string? NazivUsluge { get; set; }
    public bool Vidljivo { get; set; }

    public string? Opis { get; set; }

    public decimal? Cijena { get; set; }
    public int? autoservisId { get; set; }

    public virtual Autoservis? Autoservis { get; set; }


}
