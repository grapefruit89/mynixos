# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: system credo and architecture principles
#
# credo:
#   - Zentralitaet: Logs, Einstellungen und Configs zentral halten, keine Sonderpfade.
#   - State of the art: keine Legacy-Bremsen nur weil es leichter ist.
#   - Battle-tested Best Practice statt bleeding edge.
#   - Keine Technik, die in den naechsten Jahren abgeklaert/eingestampft wird, wenn es bereits einen etablierten Nachfolger gibt.
#
# traceability:
#   - Zentralwerte bekommen stabile IDs, damit grep/rg sofort die Fundstellen zeigt.
#   - IDs werden in Meta-Headern und in Source->Sink-Kommentaren verwendet.
#   - Schema: CFG.<gruppe>.<key>  (z.B. CFG.identity.domain)
#   - Beispiel:
#       # source-id-example: CFG.identity.domain

{ ... }:
{
}
