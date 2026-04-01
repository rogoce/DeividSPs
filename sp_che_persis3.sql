--******************************************************
-- Reporte detalle bono de persistencia para corredores
--******************************************************

-- Creado    : 14/02/2022 - Autor: Armando Moreno M.

DROP PROCEDURE sp_che_persis3;
CREATE PROCEDURE sp_che_persis3(a_cod_agente CHAR(255) default "*")
RETURNING char(5),varchar(50),char(2),char(3),char(50),char(20),integer,integer;

DEFINE _cod_agente      					 CHAR(5);
define _error,_persis,_cant_pol,_cnt,_si,_no integer;
define _error_isam,_no_pol_ren_aa_per		 integer;
define _error_desc							 char(50);
define _bono                smallint;
define _n_corredor,_n_zona  varchar(50);
define _cod_vendedor 		char(3);
define _no_documento 		char(20);
define _saber 		 		char(2);
define _tipo                char(1);

let _saber      = '';
let _cod_agente = null;

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_che_persis3.trc";
--TRACE ON;

let _persis = 0;
if a_cod_agente <> "*" then
	let _tipo = sp_sis04(a_cod_agente); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros
		foreach
			select cod_agente
			  into _cod_agente
			  from chepersisapt
			 where cant_pol >= 120
			   and cod_agente in(select codigo from tmp_codigos)
			 order by cod_agente
			
			if _cod_agente is null then
				return _cod_agente,	'', '','','','',0,0 with resume;
			end if
			let _si = 0;
			let _no = 0;	
			foreach
				select distinct no_documento
				  into _no_documento
				  from chepersisap
				 where cod_agente = _cod_agente
				 order by no_documento
				
				select count(*)
				  into _cnt
				  from chepersisaa
				 where no_documento = _no_documento;
				 
				if _cnt is null then
					let _cnt = 0;
				end if
				if _cnt > 0 then
					let _saber = 'SI';
					let _si = _si +1;
				else
					let _saber = 'NO';
					let _no = _no +1;
				end if
			 
				select nombre,
					   cod_vendedor
				  into _n_corredor,
					   _cod_vendedor
				  from agtagent
				 where cod_agente = _cod_agente;
				
				select nombre into _n_zona from agtvende
				where cod_vendedor = _cod_vendedor;
				
				return _cod_agente,	_n_corredor, _saber,_cod_vendedor,_n_zona,_no_documento,_si,_no with resume;
				 
			end foreach
		end foreach
	else
		foreach
			select cod_agente
			  into _cod_agente
			  from chepersisapt
			 where cant_pol >= 120
			   and cod_agente not in(select codigo from tmp_codigos)
			 order by cod_agente

			let _si = 0;
			let _no = 0;	
			foreach
				select distinct no_documento
				  into _no_documento
				  from chepersisap
				 where cod_agente = _cod_agente
				 order by no_documento
				
				let _cnt = 0;
				select count(*)
				  into _cnt
				  from chepersisaa
				 where cod_agente = _cod_agente
				   and no_documento = _no_documento;
				 
				if _cnt is null then
					let _cnt = 0;
				end if
				if _cnt > 0 then
					let _saber = 'SI';
					let _si = _si +1;
				else
					let _saber = 'NO';
					let _no = _no +1;
				end if
			 
				select nombre,
					   cod_vendedor
				  into _n_corredor,
					   _cod_vendedor
				  from agtagent
				 where cod_agente = _cod_agente;
				
				select nombre into _n_zona from agtvende
				where cod_vendedor = _cod_vendedor;
				
				return _cod_agente,	_n_corredor, _saber,_cod_vendedor,_n_zona,_no_documento,_si,_no with resume;
				 
			end foreach
		end foreach
	end if
	drop table tmp_codigos;
else	
	foreach
		select cod_agente
		  into _cod_agente
		  from chepersisapt
		 where cant_pol >= 120
		 order by cod_agente

		let _si = 0;
		let _no = 0;	
		foreach
			select distinct no_documento
			  into _no_documento
			  from chepersisap
			 where cod_agente = _cod_agente
			 order by no_documento
			
			let _cnt = 0;
			select count(*)
			  into _cnt
			  from chepersisaa
			 where cod_agente = _cod_agente
			   and no_documento = _no_documento;
			 
			if _cnt is null then
				let _cnt = 0;
			end if
			if _cnt > 0 then
				let _saber = 'SI';
				let _si = _si +1;
			else
				let _saber = 'NO';
				let _no = _no +1;
			end if
		 
			select nombre,
				   cod_vendedor
			  into _n_corredor,
				   _cod_vendedor
			  from agtagent
			 where cod_agente = _cod_agente;
			
			select nombre into _n_zona from agtvende
			where cod_vendedor = _cod_vendedor;
			
			return _cod_agente,	_n_corredor, _saber,_cod_vendedor,_n_zona,_no_documento,_si,_no with resume;
			 
		end foreach
	end foreach
end if
END PROCEDURE;