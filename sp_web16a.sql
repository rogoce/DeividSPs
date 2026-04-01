-- Obtener el listado de vencimineto leasing.

-- Creado    : 27/06/2012 - Autor: Federico Coronado

-- SIS - Pagina Web

drop procedure sp_web16a;

create procedure "informix".sp_web16a(a_cod_leasing char(10), a_mes integer, a_year integer)
returning char(50),
char(15),
char(15),
date,
date,
decimal(10,2),
char(15),
char(30),
char(3),
char(10),
char(3);

define _no_documento 		char(15);
define _no_poliza 			char(10);
define _no_poliza_vigente	char(10);
define _cod_contratante 	char(10);
define _cedula 				char(30);

define _vigencia_inic 		date;
define _vigencia_final 		date;
define _saldo 				decimal(10,2);
define _cod_ramo 			char(3);
define _cod_subramo 		char(3);
define _estatus_poliza 		integer;
define _estado 				char(15);
define _cod_no_renov 		char(3);
define _no_unidad 			char(5);

define _nombre 				char(60);
define _nombre_ramo 		char(30);
define _nombre_subramo 		char(20);
define _nombre_eminoren 	char(30);

set isolation to dirty read;
/*SET DEBUG FILE TO "sp_web16.trc";
TRACE ON;*/
		foreach
			/* if a_cod_ramo <> 0 then*/
				select emipomae.cod_contratante, 
				       emipomae.no_documento,
					   emipomae.cod_ramo, 
					   emipomae.vigencia_inic, 
					   emipomae.vigencia_final, 
					   cod_no_renov,
					   emipomae.no_poliza
				into _cod_contratante,
					 _no_documento,
					 _cod_ramo,
					 _vigencia_inic,
					 _vigencia_final,
					 _cod_no_renov,
					 _no_poliza
			    from emipouni inner join emipomae on emipomae.no_poliza = emipouni.no_poliza
			   where emipouni.cod_asegurado 		in(a_cod_leasing)
				 and month(emipomae.vigencia_final) = a_mes
				 and year(emipomae.vigencia_final) 	= a_year
				 and emipomae.actualizado = 1
				 and emipomae.leasing = 1
			group by 1,2,3,4,5,6,7
			order by no_documento, emipomae.vigencia_inic asc
			/* end if*/	
			
				call sp_sis21(_no_documento) returning _no_poliza_vigente;
				
				select estatus_poliza 
				  into _estatus_poliza
				  from emipomae
				 where no_poliza = _no_poliza_vigente;
			
				if _estatus_poliza = 1 then
					let _estado = "Vigente";
				elif _estatus_poliza = 2 then
					let _estado = "Cancelada";
				elif _estatus_poliza = 3 then
					let _estado = "Vencida";
				else
					let _estado = "Anulada";
				end if 	
				
					select cedula, 
						   nombre
					into _cedula,
						 _nombre
					from cliclien
					where cod_cliente = _cod_contratante;
					
					select nombre
					into _nombre_ramo				
					from prdramo 
					where cod_ramo = _cod_ramo;
					
					let _nombre_eminoren = '';
					let _saldo = sp_cob115b('001', '001', _no_documento, '');
					
					if _cod_no_renov <> '' then
						select nombre
						into _nombre_eminoren				
						from eminoren 
						where cod_no_renov = _cod_no_renov;
					end if
						   return _nombre,
								  _no_documento,
								  _nombre_ramo,
								  _vigencia_inic,
								  _vigencia_final,
								  _saldo,
								  _estado,
								  _nombre_eminoren,
								  _cod_no_renov,
								  _no_poliza_vigente,
                  				  _cod_ramo with resume; --15
        end foreach
end procedure