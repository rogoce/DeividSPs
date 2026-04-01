--DROP trigger t_update_ponbitacora;
CREATE TRIGGER t_update_ponbitacora UPDATE OF lista,pep,fundacion,cod_riesgo on ponderacion
REFERENCING OLD AS viejo NEW AS nuevo
	FOR EACH ROW(EXECUTE PROCEDURE sp_webp01() WITH TRIGGER REFERENCES);