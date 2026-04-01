{ TABLE "informix".atcdocde row size = 314 number of columns = 32 index size = 65 
              }
 
create table "informix".atcdocde 
  (
    cod_asignacion char(10) not null ,
    cod_entrada char(10) not null ,
    cod_asegurado char(10) not null ,
    cod_reclamante char(10) not null ,
    cod_icd char(10) not null ,
    cod_ajustador char(3) 
        default null,
    date_added datetime year to fraction(5) 
        default current year to fraction(5) not null ,
    user_added char(8) not null ,
    no_documento char(20) not null ,
    no_unidad char(10) not null ,
    imcs_asignar smallint 
        default 0 not null ,
    imcs_enviado smallint 
        default 0 not null ,
    imcs_fecha_enviado datetime year to fraction(5) 
        default null,
    ajustador_asignar smallint 
        default 1 not null ,
    ajustador_fecha datetime year to fraction(5),
    ajustador_asignado smallint not null ,
    datos_adjuntos byte,
    completado smallint 
        default 0 not null ,
    titulo char(40) 
        default null,
    fecha_completado datetime year to fraction(5),
    monto decimal(16,2) 
        default 0.00,
    suspenso smallint 
        default 0,
    date_susp_add datetime year to fraction(5) 
        default null,
    date_susp_rem datetime year to fraction(5) 
        default null,
    imcs_regreso smallint 
        default 0,
    imcs_fecha_regreso datetime year to fraction(5) 
        default null,
    fecha_scan datetime year to fraction(5) 
        default null,
    escaneado smallint 
        default 0,
    auditado smallint 
        default 0,
    user_scan char(8) 
        default null,
    imagen_nueva smallint 
        default 1,
    bo_ok smallint 
        default 0,
    primary key (cod_asignacion)  constraint "informix".atcdocde
  ) EXTENT SIZE 15000000
      NEXT SIZE 5000000;


revoke all on "informix".atcdocde from "public";

create index "informix".atcdocde_idx2 on "informix".atcdocde (ajustador_asignado,
    completado) using btree ;
create index "informix".atcdocde_idx3 on "informix".atcdocde (cod_ajustador,
    ajustador_asignado,completado,suspenso) using btree ;
create index "informix".atcdocde_idx_1 on "informix".atcdocde 
    (cod_ajustador,completado,suspenso) using btree ;
alter table "informix".atcdocde add constraint (foreign key (cod_entrada) 
    references "informix".atcdocma  constraint "informix".fk_atcdocde);
    




