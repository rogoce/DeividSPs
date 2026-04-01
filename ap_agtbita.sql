-- Genera Cheque ACH -- Verificador antes de generar los ach
-- Creado    : 14/09/2018 - Autor: Amado Perez
-- SIS v.2.0 - DEIVID, S.A.	
-- execute procedure sp_che177('2',0)

DROP PROCEDURE ap_agtbita;
CREATE PROCEDURE ap_agtbita() 
RETURNING  char(5),
           dec(16,2),
           char(1),							
		   char(8),
		   datetime year to fraction(5);			

DEFINE 	_i		            integer;
DEFINE 	_j			        integer;
DEFINE  _cod_agente         char(5);
DEFINE  _saldo              dec(16,2);
DEFINE	_estatus_licencia   char(1);
DEFINE	_user_changed       char(8);
DEFINE	_fecha_modif        datetime year to fraction(5);
DEFINE  _fecha_modif_max    datetime year to fraction(5); 

SET ISOLATION TO DIRTY READ;
--  set debug file to "sp_che117.trc";	
--  trace on;

let _fecha_modif_max = null;

FOR _i = 2006 TO 2022
	FOR _j = 1 TO 12
		SELECT MAX(fecha_modif)
		  INTO _fecha_modif_max
		  from agtbitacora where cod_agente = '00046' --and saldo <> 0 
		   and year(fecha_modif) = _i
		   and month(fecha_modif) = _j;
		   
		 if _fecha_modif_max is not null then  
		     foreach
				 select cod_agente, 
						saldo, 
						estatus_licencia, 
						user_changed, 
						fecha_modif 
				   into _cod_agente, 
						_saldo, 
						_estatus_licencia, 
						_user_changed, 
						_fecha_modif	 	
				   from agtbitacora 
				  where cod_agente = '00046' 
				--	and saldo <> 0
					and fecha_modif = _fecha_modif_max
					order by fecha_modif desc			
				  
				return  _cod_agente,
						_saldo, 
						_estatus_licencia, 
						_user_changed, 
						_fecha_modif  
						with resume;		
				exit foreach;
            end foreach			
		end if  
    END FOR
END FOR; 

END PROCEDURE	  