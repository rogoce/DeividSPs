drop procedure sp_rec112;

create procedure "informix".sp_rec112()

define _no_tranrec	    char(10);
define _no_reclamo	    char(10);
define _cod_cobertura	char(5);
define _variacion		dec(16,2);

foreach
 select no_tranrec
   into	_no_tranrec
   from respen0512_2
  
	update rectrmae
	   set variacion  = 0
	 where no_tranrec = _no_tranrec;

	update rectrcob
	   set variacion  = 0
	 where no_tranrec = _no_tranrec;

end foreach 

foreach
 select no_reclamo
   into	_no_reclamo
   from respen0512_2
  group by 1
  
   foreach	
	select c.cod_cobertura,
		   sum(c.variacion)
	  into _cod_cobertura,
	       _variacion
	  from rectrmae t, rectrcob c
	 where t.no_reclamo  = _no_reclamo
	   and t.no_tranrec  = c.no_tranrec
	   and t.periodo    <= "2005-12"
	   and t.actualizado = 1
	 group by 1

		update recrccob
		   set reserva_actual = _variacion
		 where no_reclamo     = _no_reclamo
		   and cod_cobertura  = _cod_cobertura;

	end foreach

end foreach 



{
insert into respen0512_2
select *
from rectrmae
where numrecla in ("18-0705-06890-01", "18-0605-05546-01", "18-0705-06155-01")
and actualizado = 1
and periodo > "2005-12"
and variacion <> 0; 
}

{
create table respen0512_2(
no_tranrec           char(10),
cod_compania         char(3),
cod_sucursal         char(3),
no_reclamo           char(10),
cod_cliente          char(10),
cod_tipotran         char(3),
cod_tipopago         char(3),
no_requis            char(10),
no_remesa            char(10),
renglon              smallint,
numrecla             char(18),
fecha                date,
impreso              smallint,
transaccion          char(10),
perd_total           smallint,
cerrar_rec           smallint,
no_impresion         smallint,
periodo              char(7),
pagado               smallint,
monto                decimal(16,2),
variacion            decimal(16,2),
generar_cheque       smallint,
actualizado          smallint,
user_added           char(8),
fecha_pagado         date,
facturado            decimal(16,2),
elegible             decimal(16,2),
a_deducible          decimal(16,2),
co_pago              decimal(16,2),
monto_no_cubierto    decimal(16,2),
coaseguro            decimal(16,2),
ahorro               decimal(16,2),
cod_cpt              char(10),
incurrido_total      decimal(16,2),
incurrido_bruto      decimal(16,2),
incurrido_neto       decimal(16,2),
pagado_proveedor     decimal(16,2),
pagado_taller        decimal(16,2),
pagado_asegurado     decimal(16,2),
pagado_tercero       decimal(16,2),
anular_nt            char(10),
user_anulo           char(10),
fecha_anulo          date,
no_factura           char(10),
fecha_factura        date,
cod_proveedor        char(10),
wf_incidente         integer,
wf_aprobado          smallint,
wf_apr_js            char(8),
wf_apr_js_fh         datetime year to fraction(5),
wf_apr_j             char(8),
wf_apr_j_fh          datetime year to fraction(5),
wf_apr_jt            char(8),
wf_apr_jt_fh         datetime year to fraction(5),
wf_apr_g             char(8),
wf_apr_g_fh          datetime year to fraction(5),
wf_inc_auto          integer,
wf_ord_com           smallint,
wf_inc_padre         integer,
wf_apr_jt_2          char(8),
wf_apr_jt_2_fh       datetime year to fraction(5)
);

alter table respen0512_2 lock mode (row);
}


end procedure