--**********************************************************
-- Procedimiento que genera el Reporte Mini Convención Miami 2019 detalle
--**********************************************************

-- Creado    : 07/01/2019 - Autor: Armando Moreno M.
-- Modificado: 14/01/2019 - Autor: Armando Moreno M.

--('00064','02484','00035','02351','02242','00279','02264','01570','01778','01979','02399','01435','01795','01471','00521')

DROP PROCEDURE sp_pro869b;
CREATE PROCEDURE sp_pro869b(a_codagente	char(255)	default "*")
RETURNING char(20),date,date,char(50),char(50),DEC(16,2),DEC(16,2),date,date,date;

DEFINE _no_documento    CHAR(20);
define _vigencia_inic, _vigencia_final date;
define _error           smallint;
define _prima_suscrita	DEC(16,2);
define _monto_pag       DEC(16,2);
define _cod_agente   	char(5);
define _fecha_pago,_vig_i,_vig_f      date;
define _nombre_ramo,_n_agente		char(50);
define _no_poliza  char(10);
define _tipo       char(1);

--SET DEBUG FILE TO "sp_pro865.trc";
--TRACE ON;

let _error          = 0;
let _prima_suscrita = 0;
let _monto_pag      = 0;
let _vig_i = "01/02/2019";
let _vig_f = "31/05/2019";

SET ISOLATION TO DIRTY READ;


--Filtro por Agente
if a_codagente <> "*" then
	let _tipo = sp_sis04(a_codagente); -- separa los valores del string


	foreach
		select cod_agente,
			   no_documento,
			   n_agente,
			   nombre_ramo,
			   prima_sus_nva
		  into _cod_agente,
			   _no_documento,
			   _n_agente,
			   _nombre_ramo,
			   _prima_suscrita
		  from punta_cana
		 where cod_agente in(select codigo from tmp_codigos)
		   and cod_ramo in('018','003','019','002')
		   and prima_sus_nva <> 0
		 order by cod_agente,nombre_ramo

		let _no_poliza = sp_sis21(_no_documento);
		let _fecha_pago = null;
		select monto_pag,fecha_pago
		  into _monto_pag,_fecha_pago
		  from emiletra
		 where no_poliza = _no_poliza
		   and no_letra = 1;
		   
		if _fecha_pago is null then
			foreach
				select fecha
				  into _fecha_pago
				  from cobredet
				 where no_poliza   = _no_poliza
				   and actualizado = 1
				   and tipo_mov    = 'P'
				exit foreach;   
			end foreach
		end if
		

		select vigencia_inic,
			   vigencia_final
		  into _vigencia_inic,
			   _vigencia_final
		  from emipomae
		 where no_poliza = _no_poliza;
		   
		RETURN _no_documento,
			   _vigencia_inic,
			   _vigencia_final,
			   _nombre_ramo,
			   _n_agente,
			   _prima_suscrita,
			   _monto_pag,
			   _fecha_pago,
			   _vig_i,
			   _vig_f
			   WITH RESUME;
	end foreach
	drop table tmp_codigos;
else
foreach
	select cod_agente,
		   no_documento,
	       n_agente,
	       nombre_ramo,
	       prima_sus_nva
	  into _cod_agente,
		   _no_documento,
		   _n_agente,
		   _nombre_ramo,
		   _prima_suscrita
	  from punta_cana
	 where cod_ramo in('018','003','019','002')
	   and prima_sus_nva <> 0
	 order by cod_agente,nombre_ramo

    let _no_poliza = sp_sis21(_no_documento);
	let _fecha_pago = null;
	select monto_pag,fecha_pago
	  into _monto_pag,_fecha_pago
	  from emiletra
	 where no_poliza = _no_poliza
       and no_letra = 1;
	   
	if _fecha_pago is null then
		foreach
			select fecha
			  into _fecha_pago
			  from cobredet
             where no_poliza   = _no_poliza
               and actualizado = 1
			   and tipo_mov    = 'P'
			exit foreach;   
		end foreach
	end if
	

	select vigencia_inic,
	       vigencia_final
	  into _vigencia_inic,
	       _vigencia_final
	  from emipomae
	 where no_poliza = _no_poliza;
	   
    RETURN _no_documento,
	       _vigencia_inic,
		   _vigencia_final,
		   _nombre_ramo,
		   _n_agente,
		   _prima_suscrita,
		   _monto_pag,
		   _fecha_pago,
		   _vig_i,
		   _vig_f
           WITH RESUME;
end foreach
end if
END PROCEDURE;