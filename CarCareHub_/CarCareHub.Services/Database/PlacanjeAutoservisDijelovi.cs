using System;
using System.Collections.Generic;

namespace CarCareHub.Services.Database;

public partial class PlacanjeAutoservisDijelovi
{
    public int PlacanjeId { get; set; }

    public DateTime? Datum { get; set; }

    public double? Iznos { get; set; }

    public int? Posiljaoc { get; set; }

    public int? Primalac { get; set; }

    public virtual Autoservis? PosiljaocNavigation { get; set; }

    public virtual FirmaAutodijelova? PrimalacNavigation { get; set; }
}
