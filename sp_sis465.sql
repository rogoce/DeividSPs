--POLIZAS VIGENTES POR RAMO
--Creado : 08/10/2000 - Autor: Yinia Zamora
--Modificado: 16/08/2001 -Autor: Marquelda Valdelamar (inclusion de filtro de cliente)
--Modificado: 05/09/2001 -Autor: Marquelda Valdelamarinclusion de filtro de poliza
-- Modificado: 23/04/2018  - Autor: Henry Giron (Filtro por Zona), DALBA
--SIS v.2.0 - DEIVID, S.A.
--execute procedure sp_pro32f('001','001','16/08/2012',"*","*","*","*","*","39852;","*","*")

drop procedure sp_sis465;
create procedure sp_sis465(a_periodo_ant char(7),a_periodo_act char(7)) 

returning	integer    as dia,
			dec(16,2)  as prima_cobrada_ant,
			dec(16,2)  as acumulado_ant,
			dec(16,2)  as prima_cobrada_act,
			dec(16,2)  as acumulado_act,
			dec(16,2)  as no_cobrado,
			dec(16,2)  as porc_cobrado;


define _monto,_acum,_monto1	dec(16,2);
define _fecha	date;
define _fecha_int integer;
define _monto2,_acum2,_no_cobrado,_porc_cobrado dec(16,2);
define _fecha_ini,_fecha_fin date;

let _monto = 0;
let _monto1 = 0;
let _monto2 = 0;
let _acum2 = 0;
let _no_cobrado = 0;

set isolation to dirty read;

create temp table temp_perfil(
fecha			    date,
monto1      		dec(16,2),
monto2      		dec(16,2),
acumulado1			dec(16,2),
no_cobrado			dec(16,2),
acumulado2			dec(16,2),
porc_cobrado        dec(16,2)
) WITH NO LOG;

--año y mes anterior sin fronting
let _acum = 0;

let _fecha_ini = mdy(a_periodo_ant[6,7], 1, a_periodo_ant[1,4]);
let _fecha_fin = sp_sis36(a_periodo_ant);

foreach

	select t.date_posteo,
		   sum(c.monto)
	  into _fecha,
		   _monto
	  from cobredet c, cobremae t
	 where c.no_remesa = t.no_remesa
           and c.periodo = a_periodo_ant
	   and c.actualizado = 1
	   and c.tipo_mov in('P','N')
	   and no_poliza in (select no_poliza from emipomae
	                      where actualizado = 1
	                        and fronting = 0
							and cod_tipoprod <> '004')
	group by t.date_posteo
	order by t.date_posteo

	let _acum = _acum + _monto;
	 
	insert into temp_perfil
	(fecha,monto1,acumulado1,no_cobrado,monto2,acumulado2,porc_cobrado)
	values(_fecha,_monto,_acum,0,0,0,0);

end foreach
--******************************************
--año y mes actual sin fronting
--******************************************
let _acum = 0;

let _fecha_ini = mdy(a_periodo_act[6,7], 1, a_periodo_act[1,4]);
let _fecha_fin = sp_sis36(a_periodo_act);
foreach
	select t.date_posteo,
		   sum(c.monto)
	  into _fecha,
		   _monto
	  from cobredet c, cobremae t
	 where c.no_remesa = t.no_remesa
           and c.periodo = a_periodo_act
	   and c.actualizado = 1
	   and c.tipo_mov in('P','N')
	   and no_poliza in (select no_poliza from emipomae
	                      where actualizado = 1
	                        and fronting = 0
							and cod_tipoprod <> '004')
	group by t.date_posteo
	order by t.date_posteo

	let _acum = _acum + _monto;
	
	update temp_perfil
	   set monto2     = _monto,
	       acumulado2 = _acum
	 where day(fecha) = day(_fecha);
	 
	foreach
		select acumulado1
		  into _monto1 
		  from temp_perfil
		 where day(fecha) = day(_fecha)
	
		let _porc_cobrado = _acum * 100 / _monto1;
	end foreach	
	
	update temp_perfil
       set no_cobrado = monto1 - _acum,
	       porc_cobrado = _porc_cobrado
     where day(fecha) = day(_fecha);

end foreach

foreach
	select day(fecha),
	       monto1,
		   acumulado1,
		   monto2,
		   acumulado2,
		   no_cobrado,
		   porc_cobrado
	  into _fecha_int,
           _monto,
           _acum,
           _monto2,
           _acum2,
		   _no_cobrado,
		   _porc_cobrado
	  from temp_perfil	   


	return	_fecha_int, _monto,_acum,_monto2,_acum2,_no_cobrado,_porc_cobrado with resume;

end foreach
drop table temp_perfil;
end procedure;