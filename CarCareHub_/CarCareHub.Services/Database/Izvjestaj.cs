using System;
using System.Collections.Generic;

namespace CarCareHub.Services.Database;

public partial class Izvjestaj
{
    public int IzvjestajId { get; set; }

    public virtual ICollection<FirmaAutodijelova> FirmaAutodijelovas { get; set; } = new List<FirmaAutodijelova>();
    public bool Vidljivo { get; set; }
}
