-- Reporte del Cierre de Caja - Detallado
-- Creado    : 01/02/2010 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 19/05/2017 - Autor: Federico Coronado
-- SIS v.2.0 - d_cobr_cierre_caja_automatico_reporte - DEIVID, S.A.

drop procedure comparar;

create procedure "informix".comparar()
returning integer,
          char(1),
          char(30);  --21

define _no_documento_aa     char(20);
define _prima_aa     		dec(16,2);
define	_id_aa				integer;   
define _no_documento_tt     char(20);
define _prima_tt     		dec(16,2);
define	_id_tt				integer;
define _no_unidad_aa        char(5);
define _vig_ini_aa          date;
define _vig_fin_aa          date;
define _periodo_aa          char(7);
define _no_unidad_tt        char(5);
define _vig_ini_tt          date;
define _vig_fin_tt          date;
define _fecha_tt           date;
define  _no_documento_gb   char(20);

set isolation to dirty read;

--set debug file to "comparar.trc";
--trace on;

drop table if exists tmp_tecnica;

create temp table tmp_tecnica(
no_documento_aa		char(20),
no_unidad_aa        char(5),
vig_ini_aa          date,
vig_fin_aa          date,
periodo_aa          char(7),
prima_aa			dec(16,2),
no_documento_tt     char(20),
no_unidad_tt        char(5),
vig_ini_tt          date,
vig_fin_tt          date,
fecha_tt            date,
prima_tt            dec(16,2)
) with no log;

update ancon_tecnica
   set marcada = 0;	
 
 update tecnica_ancon
   set marcada = 0;

foreach
	select no_documento
	  into _no_documento_gb
	 from poliza_tecnica 
  
		foreach
			select no_documento, no_unidad, vigencia_inicial, vigencia_final, periodo, prima_bruta, id
			  into	_no_documento_aa, _no_unidad_aa, _vig_ini_aa, _vig_fin_aa, _periodo_aa, _prima_aa,	_id_aa
			  from ancon_tecnica
			 where marcada = 0 
			   and no_documento =	_no_documento_gb
		  order by no_documento
		  
			let _no_documento_tt = "";
			let _prima_tt 		 = "";
			let _no_unidad_tt 	 = "";
			let _vig_ini_tt 	 = "";
			let	_vig_fin_tt 	 = "";
			let	_fecha_tt 		 = "";
			let _id_tt    		 = "";
			
		  foreach
			select no_documento, no_unidad,vigencia_inicial,vigencia_final, fecha, prima_bruta, id
			  into _no_documento_tt, _no_unidad_tt, _vig_ini_tt, _vig_fin_tt, _fecha_tt, _prima_tt,_id_tt
			  from tecnica_ancon
			 where no_documento =	_no_documento_gb
			 and prima_bruta = _prima_aa
			 and marcada = 0 
			 exit foreach;
		  end foreach 
		  
		insert into tmp_tecnica
				values (_no_documento_aa, _no_unidad_aa, _vig_ini_aa, _vig_fin_aa, _periodo_aa, _prima_aa, _no_documento_tt, _no_unidad_tt, _vig_ini_tt, _vig_fin_tt, _fecha_tt, _prima_tt);

		update	ancon_tecnica
		   set	marcada	= 1
		 where	id =	_id_aa;
		 
		 update	tecnica_ancon
		   set	marcada	= 1
		 where	id =	_id_tt;
		 
		end foreach

		foreach
			select no_documento, no_unidad,vigencia_inicial,vigencia_final, fecha, prima_bruta, id
			  into	_no_documento_tt, _no_unidad_tt, _vig_ini_tt, _vig_fin_tt, _fecha_tt, _prima_tt, _id_tt
			  from tecnica_ancon
			 where marcada = 0 
			   and no_documento = _no_documento_gb

			insert into tmp_tecnica
				values ("","","","","","",_no_documento_tt, _no_unidad_tt, _vig_ini_tt, _vig_fin_tt, _fecha_tt, _prima_tt);
				
			 update tecnica_ancon
			   set marcada = 1
			 where id =	_id_tt;
			 
		end foreach 
 	return	0, 
	       "",
		   ""
	with resume;
end foreach

end procedure
