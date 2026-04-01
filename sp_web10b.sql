-- Obtener el estado de los reclamos el modulo web de consulta corredores

-- Creado: 29/11/2011 - Autor: Federico Coronado

-- SIS - Pagina Web consulta de el estado de los reclamos modulo de los corredores consultas web.

drop procedure sp_web10b;

create procedure "informix".sp_web10b(a_cod_reclamante varchar(10))
returning char(20);

define _cnt_pol 			smallint;
define _no_documento		varchar(20);
define _cod_ramo			varchar(3);
define _no_poliza 			varchar(10);
define _fecha               date;

--set debug file to "sp_web10b.trc";
--trace on;

let _fecha   = today;
let _fecha   = _fecha - 730 units day;
/*let _periodo = sp_sis39(_fecha);*/

foreach
	 select distinct(no_documento)
	   into _no_documento	 
	   from recrcmae 
	  where (cod_asegurado = a_cod_reclamante or cod_reclamante = a_cod_reclamante) 
	    and recrcmae.actualizado = 1 
	    and recrcmae.fecha_reclamo >= _fecha
		
	 let _no_poliza = sp_sis21(_no_documento);
	 
	 select cod_ramo
	   into _cod_ramo
	   from emipomae
	  where no_poliza = _no_poliza;
	  
	  if _cod_ramo = '018' then
	  
		   SELECT count(*)
		     into _cnt_pol
			 FROM recrcmae inner join rectrmae on recrcmae.no_reclamo = rectrmae.no_reclamo
			where recrcmae.cod_compania = '001'
			  and recrcmae.actualizado  = 1
			  and cod_tipotran in ('013', '004')
			  and anular_nt    is null
			  and rectrmae.transaccion is not null
			  and recrcmae.no_documento = _no_documento
			  and (cod_asegurado = a_cod_reclamante or cod_reclamante = a_cod_reclamante)
			  and fecha_reclamo >= _fecha
			  and cod_tipopago = '003';
			  
			if _cnt_pol = 0 then
				continue foreach;
			end if
			
	  end if
	 
		   return         _no_documento
						  with resume;

	end foreach

end procedure