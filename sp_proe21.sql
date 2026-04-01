-- Procedimiento para buscar el valor del descuento
-- f_emision_busca_descuento
--
-- Creado    : 05/01/2000 - Autor: Edgar E. Cano G.
-- Modificado: 05/01/2000 - Autor: Edgar E. Cano G.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_proe21;
CREATE PROCEDURE "informix".sp_proe21(a_poliza CHAR(10), a_unidad CHAR(5), a_prima DEC(16,2))
RETURNING   DECIMAL(16,2); -- ld_descuento

define li_lin, li_return, li_orden  integer;
define ld_porc, ld_porc_desc		decimal(16,4);
define ld_descuento, ld_descuen_tot	decimal(16,2);
define ls_cod_descuen				char(3);
define _valor						smallint;
define _mensaje						char(20);
define _porc_desc_max				decimal(16,2);

begin

set isolation to dirty read;

let ld_descuento   = 0.00;
let ld_descuen_tot = 0.00;
let _valor         = 0;
let _mensaje       = '';
let _porc_desc_max = 0;

--SET DEBUG FILE TO "sp_proe21.trc";
--TRACE ON;

foreach
 select emidescu.orden, 
        emiunide.cod_descuen,
        emiunide.porc_descuento
   into li_orden, 
        ls_cod_descuen, 
        ld_porc_desc
   from emidescu, emiunide  
  where emiunide.no_poliza   = a_poliza
    and emiunide.no_unidad   = a_unidad 
    and emiunide.cod_descuen = emidescu.cod_descuen
  order by emidescu.orden
	
	if ls_cod_descuen = '001' then	-- Descuento de Buena Experiencia

		call sp_sis194(a_poliza,a_unidad,ld_porc_desc) returning _valor, _mensaje, _porc_desc_max;

		if _valor = 1 then
			
    		update emiunide
			   set porc_descuento = _porc_desc_max
			 where no_poliza      = a_poliza
			   and no_unidad      = a_unidad
			   and cod_descuen    = ls_cod_descuen;

			let ld_porc_desc = _porc_desc_max;

		end if

	end if

	let ld_porc        = ld_porc_desc / 100;
  	let ld_descuento   = a_prima * ld_porc;
  	let a_prima        = a_prima - ld_descuento;
  	let ld_descuen_tot = ld_descuen_tot + ld_descuento;

end foreach

return ld_descuen_tot;

end

end procedure;
