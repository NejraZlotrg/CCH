using System;
using System.Collections.Generic;

namespace CarCareHub.Services.Database;

public partial class Popust
{
    public int PopustId { get; set; }

    public int? AutoservisId { get; set; }

    public int? FirmaAutodijelovaId { get; set; }

    public double? VrijednostPopusta { get; set; }

    public virtual Autoservis? Autoservis { get; set; }

    public virtual FirmaAutodijelova? FirmaAutodijelova { get; set; }

    public virtual ICollection<Narudzba> Narudzbas { get; set; } = new List<Narudzba>();
}
