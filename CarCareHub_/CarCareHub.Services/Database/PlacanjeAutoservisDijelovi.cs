using System;
using System.Collections.Generic;

namespace CarCareHub.Services.Database;

public partial class PlacanjeAutoservisDijelovi
{
    public int PlacanjeId { get; set; }

    public DateTime? Datum { get; set; }

    public double? Iznos { get; set; }

    public int? AutoservisId { get; set; }

    public int? FirmaAutodijelovaID { get; set; }

    public virtual Autoservis? Autoservis { get; set; }

    public virtual FirmaAutodijelova? FirmaAutodijelova { get; set; }
    public bool Vidljivo { get; set; }
}
