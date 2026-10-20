package soulsoft_extensions_logging.annotations

@Annotation[target: [Type]]
public class ProviderAlias {
    private let _alias: String

    public const init(alias: String) {
        _alias = alias
    }

    public prop alias: String {
        get() {
            _alias
        }
    }
}
