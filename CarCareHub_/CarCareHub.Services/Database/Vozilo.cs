using System;
using System.Collections.Generic;

namespace CarCareHub.Services.Database;

    public partial class Vozilo
    {
        public int VoziloId { get; set; }
        public string? MarkaVozila { get; set; }
    public bool Vidljivo { get; set; }
    public virtual ICollection<Model> Models { get; set; } = new List<Model>(); //Njera dodala za vozila

    public virtual ICollection<Autoservis> Autoservis { get; set; } = new List<Autoservis>();
        public virtual ICollection<Proizvod> Proizvods { get; set; } = new List<Proizvod>();
    }
